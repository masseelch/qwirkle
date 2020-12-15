package qwirkle

import (
	"encoding/json"
	"github.com/gorilla/websocket"
	"log"
	"strconv"
	"time"
)

const (
	messageDrawCubes  = "draw_cubes"
	messageSwapCubes  = "swap_cubes"
	messagePlaceCubes = "place_cubes"
	messageRollCubes  = "roll_cubes"
)

type (
	Client struct {
		hub *Hub

		nickname string

		// websocket
		conn *websocket.Conn

		// buffered channel of outbound messages
		send chan []byte
	}
	Message struct {
		Type string            `json:"type"`
		Meta map[string]string `json:"meta"`
		Data json.RawMessage   `json:"data"`
	}
)

// readPump pumps messages from the websocket connection to the hub.
//
// The application runs readPump in a per-connection goroutine. The application
// ensures that there is at most one reader on a connection by executing all
// reads from this goroutine.
func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error { c.conn.SetReadDeadline(time.Now().Add(pongWait)); return nil })

	for {
		_, message, err := c.conn.ReadMessage()

		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			}
			break
		}

		m := new(Message)
		if err := json.Unmarshal(message, m); err != nil {
			log.Printf("error: %v", err)
			break
		}

		switch m.Type {

		case messageDrawCubes:
			a, err := strconv.Atoi(m.Meta["amount"])
			if err != nil {
				log.Printf("error: %v", err)
				break
			}

			cs := c.hub.game.DrawCubes(a)
			ecs, err := json.Marshal(cs)
			if err != nil {
				log.Printf("error: %v", err)
				break
			}

			d, err := json.Marshal(Message{
				Type: messageDrawCubes,
				Meta: map[string]string{"for": c.nickname},
				Data: ecs,
			})
			if err != nil {
				log.Printf("error: %v", err)
				break
			}

			c.hub.broadcast <- d

		case messageSwapCubes:
			var old []Cube
			if err := json.Unmarshal(m.Data, &old); err != nil {
				log.Printf("error: %v", err)
				break
			}

			cs := c.hub.game.DrawCubes(len(old))
			c.hub.game.AddCubes(old)

			ecs, err := json.Marshal(cs)
			if err != nil {
				log.Printf("error: %v", err)
				break
			}

			d, err := json.Marshal(Message{
				Type: messageSwapCubes,
				Meta: map[string]string{"for": c.nickname},
				Data: ecs,
			})
			if err != nil {
				log.Printf("error: %v", err)
				break
			}

			c.hub.broadcast <- d

		case messageRollCubes:
			// Check if the player is allowed to roll this cubes (he has them in his board.
			var toRoll []Cube
			if err := json.Unmarshal(m.Data, &toRoll); err != nil {
				log.Printf("error: %v", err)
				break
			}

			for i, cb := range toRoll {
				if !c.hub.game.Players[c.nickname].HasCube(cb) {
					log.Printf("error: Player does not have cube %v", cb)
					break
				}

				c.hub.game.RollCube(&toRoll[i])
			}

			ecs, err := json.Marshal(toRoll)
			if err != nil {
				log.Printf("error: %v", err)
				break
			}

			d, err := json.Marshal(Message{
				Type: messageRollCubes,
				Meta: map[string]string{"for": c.nickname},
				Data: ecs,
			})
			if err != nil {
				log.Printf("error: %v", err)
				break
			}

			c.hub.broadcast <- d

		case messagePlaceCubes:



		default:
			log.Println("Default case reached")
		}
	}
}

// writePump pumps messages from the hub to the websocket connection.
//
// A goroutine running writePump is started for each connection. The
// application ensures that there is at most one writer to a connection by
// executing all writes from this goroutine.
func (c *Client) writePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()
	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				// The hub closed the channel.
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// Add queued chat messages to the current websocket message.
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}
		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
