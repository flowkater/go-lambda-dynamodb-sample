package main

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/expression"
)

type Table[T any, S any] struct {
	name string
	db   *dynamodb.DynamoDB
}

func (t *Table[T, S]) Init(name string) {
	db := dynamodb.New(session.New(), &aws.Config{Region: aws.String("ap-northeast-2")})
	t.name = name
	t.db = db
}

func (t *Table[T, S]) PutItem(item T) error {
	av, err := dynamodbattribute.MarshalMap(item)
	if err != nil {
		fmt.Println("Got error marshalling attribute item:")
		fmt.Println(err.Error())
		return err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(t.name),
	}

	_, err = t.db.PutItem(input)
	if err != nil {
		fmt.Println("Got error calling PutItem:")
		fmt.Println(err.Error())
		return err
	}
	return nil
}

func (t *Table[T, S]) ListItem(hashKeyName string, hashKeyValue string, paginated bool, from S) (*dynamodb.QueryOutput, error) {
	hash := expression.Key(hashKeyName).Equal(expression.Value(hashKeyValue))
	expr, err := expression.NewBuilder().WithKeyCondition(hash).Build()

	if err != nil {
		fmt.Println("Got error building expression:")
		fmt.Println(err.Error())
		return nil, err
	}

	query := dynamodb.QueryInput{
		KeyConditionExpression:    expr.KeyCondition(),
		ExpressionAttributeValues: expr.Values(),
		ExpressionAttributeNames:  expr.Names(),
		TableName:                 aws.String(t.name),
		Limit:                     aws.Int64(10),
	}

	if paginated {
		exKey, err := dynamodbattribute.MarshalMap(from)
		if err != nil {
			fmt.Println("Got error marshalling expression key:")
			fmt.Println(err.Error())
			return nil, err
		} else {
			query.ExclusiveStartKey = exKey
		}
	}

	result, err := t.db.Query(&query)

	if err != nil {
		fmt.Println("Got error calling Query:")
		fmt.Println(err.Error())
		return nil, err
	}

	return result, nil
}

// Update item in dynamodb table
func (t *Table[T, S]) UpdateItem(key S, expr expression.Expression) (*dynamodb.UpdateItemOutput, error) {

	k, err := dynamodbattribute.MarshalMap(key)
	if err != nil {
		fmt.Println("Got error marshalling key item:")
		fmt.Println(err.Error())
		return nil, err
	}

	input := &dynamodb.UpdateItemInput{
		Key:                       k,
		ExpressionAttributeNames:  expr.Names(),
		ExpressionAttributeValues: expr.Values(),
		TableName:                 aws.String(t.name),
		ReturnValues:              aws.String("ALL_NEW"),
		UpdateExpression:          expr.Update(),
	}

	result, err := t.db.UpdateItem(input)
	if err != nil {
		fmt.Println("Got error UpdateItem:")
		fmt.Println(err.Error())
		return nil, err
	}

	return result, nil
}

// Delete item in dynamodb table
func (t *Table[T, S]) DeleteItem(key S) error { // 에러가 없으면 잘 삭제된 것이다.

	k, err := dynamodbattribute.MarshalMap(key)
	if err != nil {
		fmt.Println("Got error marshalling key item:")
		fmt.Println(err.Error())
		return err
	}

	input := &dynamodb.DeleteItemInput{
		Key:       k,
		TableName: aws.String(t.name),
	}

	_, err = t.db.DeleteItem(input)
	if err != nil {
		fmt.Println("Got error DeleteItem:")
		fmt.Println(err.Error())
		return err
	}

	return nil
}
