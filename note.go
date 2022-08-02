package main

import (
	"fmt"
	"strconv"
	"time"

	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/expression"
)

var noteTable *Table[note, NoteKey]

func init() {
	noteTable = &Table[note, NoteKey]{}
	noteTable.Init("go-note-api2")
}

type note struct {
	User      string    `json:"user"`
	Id        string    `json:"id"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	UpdatedAt time.Time `json:"updated_at"`
	CreatedAt time.Time `json:"created_at"`
}

type NoteKey struct {
	Id   string `json:"id"`
	User string `json:"user"`
}

func createNote(user string, m note) (*note, error) {
	_m := note{
		User:      user,
		Content:   m.Content,
		Id:        strconv.FormatInt(time.Now().UTC().UnixNano()/1000, 10),
		Title:     m.Title,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	err := noteTable.PutItem(_m)
	if err != nil {
		return nil, err
	}

	return &_m, nil
}

type noteQueryResult struct {
	Notes            []note  `json:"notes"`
	Count            int64   `json:"count"`
	ScannedCount     int64   `json:"scannedCount"`
	LastEvaluatedKey NoteKey `json:"lastEvaluatedKey"`
}

func getNotes(user string, from string) (*noteQueryResult, error) {
	result, err := noteTable.ListItem("user", user, from != "", NoteKey{User: user, Id: from})
	if err != nil {
		return nil, err
	}

	notes := make([]note, len(result.Items))
	for i, v := range result.Items {
		dynamodbattribute.UnmarshalMap(v, &notes[i])
	}

	lastEvaluatedKey := NoteKey{}

	if result.LastEvaluatedKey != nil {
		dynamodbattribute.UnmarshalMap(result.LastEvaluatedKey, &lastEvaluatedKey)
	}

	noteQueryResult := noteQueryResult{
		Notes:            notes,
		Count:            *result.Count,
		ScannedCount:     *result.ScannedCount,
		LastEvaluatedKey: lastEvaluatedKey,
	}

	return &noteQueryResult, nil
}

func updateNote(user string, id string, m note) (*note, error) {

	update := expression.UpdateBuilder{}
	update = update.Set(expression.Name("updatedAt"), expression.Value(time.Now()))
	if m.Title != "" {
		update = update.Set(expression.Name("title"), expression.Value(m.Title))
	}
	if m.Content != "" {
		update = update.Set(expression.Name("content"), expression.Value(m.Content))
	}

	expr, err := expression.NewBuilder().WithUpdate(update).Build()

	if err != nil {
		fmt.Println("Got error building expression:")
		fmt.Println(err.Error())
		return nil, err
	}

	result, err := noteTable.UpdateItem(NoteKey{Id: id, User: user}, expr)

	if err != nil {
		return nil, err
	}

	updatedNote := note{}
	dynamodbattribute.UnmarshalMap(result.Attributes, &updatedNote)

	return &updatedNote, nil
}

func deleteNote(user string, id string) error {
	if err := noteTable.DeleteItem(NoteKey{Id: id, User: user}); err != nil {
		return err
	}
	return nil
}
