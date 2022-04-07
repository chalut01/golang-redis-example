package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gomodule/redigo/redis"
	"google.golang.org/appengine"
)

var redisPool *redis.Pool

func main() {
	redisAddr := os.Getenv("REDIS_ADDR")
	redisPassword := os.Getenv("REDIS_PASSWORD")

	redisPool = &redis.Pool{
		Dial: func() (redis.Conn, error) {
			conn, err := redis.Dial("tcp", redisAddr)
			if redisPassword == "" {
				return conn, err
			}
			if err != nil {
				return nil, err
			}
			if _, err := conn.Do("AUTH", redisPassword); err != nil {
				conn.Close()
				return nil, err
			}
			return conn, nil
		},
		// TODO: Tune other settings, like IdleTimeout, MaxActive, MaxIdle, TestOnBorrow.
	}
	http.HandleFunc("/", handle)
	log.Fatal(http.ListenAndServe(":8080", nil))
	appengine.Main()
}

func handle(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	redisConn := redisPool.Get()
	defer redisConn.Close()

	count, err := redisConn.Do("INCR", "count")
	if err != nil {
		msg := fmt.Sprintf("Could not increment count: %v", err)
		http.Error(w, msg, http.StatusInternalServerError)
		return
	}
	fmt.Fprintf(w, "Count: %d", count)
}
