push:
	heroku container:push web -a jkmrto

release:
	heroku container:release web -a jkmrto
run:
	iex -S mix phx.server

heroku-logs:
	heroku logs -t -a jkmrto 
