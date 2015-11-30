FROM jenkins

MAINTAINER Jacob Blain Christen <mailto:dweomer5@gmail.com, https://github.com/dweomer, https://twitter.com/dweomer>

COPY src/main/resources/plugins.txt /usr/share/jenkins/

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

COPY src/main/groovy/init/*.groovy /usr/share/jenkins/ref/init.groovy.d/