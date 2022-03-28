package main

import "fmt"
import "net/http"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Are you trying to visit %s ?", r.URL.Path)
	})

	http.ListenAndServe(":8080", nil)
}