package main

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func createServer() *echo.Echo {
	e := echo.New()
	e.Use(middleware.CORS())
	e.GET("/note", func(c echo.Context) error {
		return c.NoContent(http.StatusOK)
	})
	return e
}
