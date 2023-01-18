FROM public.ecr.aws/amazonlinux/amazonlinux:latest

# Install Python, and other useful utils
RUN yum install -y update yum-utils; \
    yum install -y amazon-linux-extras python3 git jq yq zip unzip gzipu tar nodejs gcc gcc-c++ make;

# Install Boto3, Python CDK and requests
RUN pip3 install boto3 requests Jinja2 --no-cache-dir

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    unzip -q awscliv2.zip; \
    ./aws/install; \
    rm awscliv2.zip; \
    rm -rf aws; \
    aws --version;

# Install AWS SAM
RUN curl -L#o aws-sam-cli-linux-x86_64.zip https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip; \
    sha256sum aws-sam-cli-linux-x86_64.zip; \
    unzip -q aws-sam-cli-linux-x86_64.zip -d sam-installation; \
    ./sam-installation/install; \
    rm -rf sam-installation; \
    rm -f aws-sam-cli-linux-x86_64.zip; \
    sam --version

# Install Attini CLI
RUN /bin/bash -c "$(curl -fsSL https://docs.attini.io/blob/attini-cli/install-cli.sh)"


# Install brew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"; \
    echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> /root/.profile

ENV PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Install Hugo with brew (we had some issues getting the latest version when we used apt or dnf)
RUN brew install hugo dasel;  \
    hugo version

# Update and clear cashes
RUN yum update -y; \
    yum clean all && rm -rf /var/cache/yum && rm -rf /root/.cache/pip;
