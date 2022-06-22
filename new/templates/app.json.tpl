[
  {
    "essential": true,
    "memory": 1024,
    "name": "django",
    "cpu": 2048,
    "image": "${REPOSITORY_URL}:mweb-cdn",
    "portMappings": [
        {
            "containerPort": 4000,
            "hostPort": 4000
        }
    ]
  }
]

