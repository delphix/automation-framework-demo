FROM amazonlinux
RUN yum update -y
RUN yum install -y java-1.8.0 maven gcc-c++ make
RUN curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
RUN yum -y install nodejs yarn
RUN npm install -g @angular/cli
RUN ng config -g cli.packageManager yarn
