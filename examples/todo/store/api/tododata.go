package api

type Todo struct {
	ID	string `json:"id"`
	Name      string    `json:"name"`
	Description string `json:"description"`
	Completed bool      `json:"completed"`
	Due       string `json:"due"`
	Create	string `json:"create"`
	Owner	string	`json:"owner"`
}

var LocalCache map[string]Todo

// sample
//	{
//		"id":"100000001",
//		"name":"test1",
//		"description":"test",
//		"completed": false,
//		"due":"2018-09-22T12:42:31+08:00",
//		"create":"2018-09-22T12:42:31+08:00",
//		"owner":"chen"
//	}