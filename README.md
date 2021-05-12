# tortilla2teams
## Spanish omelette as a Service

### What?
This is a minimal icebreaker app sending messages to MS Teams. You can send a json to the *tortilla* endpoint with a list of people and it will send an invitation to a MS Teams channel with some names of the list randomly elected.

### How to build it?
You will need a D compiler installed (DMD/ldc/...), a C compiler and the DUB package manager. You also will need the sources of phobos library, zlib and openssl lib.

With all these elements, you only need to run `dub install` in this directory.

Alternatively, there is a [Dockerfile](Dockerfile) that you can use to build a container.

### How to run it?
In order to run tortilla2teams, you must have installed zlib, openssl library and phobos.
Then you can execute the binary:
```
$ ./tortilla2teams 
[main(----) INF] Listening for requests on http://127.0.0.1:9000
```
By default, the service will listen at 127.0.0.1:9000 but you can override this value exporting TORTILLA\_HOST and TORTILLA\_PORT environment variables.

You also can use the Docker image, vg.:
```
$ docker pull frantsao/tortilla2teams:latest
$ docker run -p 9000:9000 -e TORTILLA_HOST=0.0.0.0 frantsao/tortilla2teams:latest
```

Then you can send a POST to /api/tortilla path with a json payload like [data.json](test/data.json). With this configuration example, the hook will be sent to a test endpoint in the same tortilla service; you must change the notificationUrl with the webhook url you created in your MS Teams channel:
```
$ http 127.0.0.1:9000/api/tortilla < data.json 
HTTP/1.1 200 OK
Content-Length: 54
Content-Type: application/json
Date: Tue, 04 May 2021 23:25:50 GMT
Keep-Alive: timeout=10
Server: vibe.d/1.16.0

{
    "OK": "Invitations sent, prepare tortilla and coffee"
}
```
(promised if I continue working in this program I'll improve testing)

I sent the request in the example using the wonderful [HTTPie](https://httpie.io/).

### Why?

The idea came from a conversation with [@dortegau](https://github.com/dortegau) some weeks ago. We were looking to strengthen ties in our remote team at [idealista](https://idealista.com) via tiny social meetings. At that time I read [a post about D language programming](https://opensource.com/article/21/1/d-scripting). I had a problem and a tool that I wanted learning about it.

### How?
This has been my documentation:
- [The D language programming web](https://dlang.org/)
- [The vibe.d library web](https://vibed.org/)
- [The Programming in D book](https://ddili.org/ders/d.en/index.html)
- [The Microsoft Teams webhooks documentation](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/connectors-using)

### Status
I want to believe it's an [MVP](https://en.wikipedia.org/wiki/Minimum_viable_product) ;-)

### Built With

![DMD](https://img.shields.io/badge/DMD-2.085.1-green.svg)
![DUB](https://img.shields.io/badge/DUB-1.14.0-green.svg)
![vibe.d](https://img.shields.io/badge/vibe.d-0.9.3-green.svg)

### About
![AGPLv3](https://img.shields.io/badge/License-AGPLv3-orange)

This work is under AGPLv3 license (see see the [LICENSE](LICENSE) file) with the exception of the Spanish [omelette photo](test/tortilla.png) in the test directory. It has been created by Amasuela - Luis Lafuente Agudín - own job, CC BY-SA 4.0. The original file is at https://commons.wikimedia.org/w/index.php?curid=78914533 I made some cropping and scaling in order to use it as Teams avatar.

