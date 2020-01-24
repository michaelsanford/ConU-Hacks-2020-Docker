package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", hello)
	http.ListenAndServe(":8081", nil)
}

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Println(fmt.Sprintf("Saying hello to %s!", r.URL.Path[1:]))
	fmt.Fprintf(w, "<h1>Hello, %s from Project B!</h1>", r.URL.Path[1:])
}
