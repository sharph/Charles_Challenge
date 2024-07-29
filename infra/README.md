# Challenge solution

## How to run

Make sure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` is set in the
environment.

Install terraform, run `terraform init` in this directory, then run
`terraform apply`. At the prompt, type `yes`.

Terraform will set up a self-signed certificate, VPC, load balancer,
security groups, Fargate tasks, etc. The Fargate task specified installs the
desired contents to index.html, then runs nginx.

If successful, Terraform will output the web address of the created load balancer.

```
Apply complete! Resources: 50 added, 0 changed, 0 destroyed.

Outputs:

web_address = "https://sharp-sed-JUST_AN_EXAMPLE.us-east-1.elb.amazonaws.com/"
```

After creating resources, the load balancer and application may take a minute or
two to become healthy.

## Automated Test

Set the `URL` environment variable, then run `python3 test.py` to ensure:

* The result from connecting to the URL contains the string "Hello World!"
* Connecting to HTTP redirects to HTTPS
* Connecting on port 1234 times out

```
URL=https://sharp-sed-JUST_AN_EXAMPLE.us-east-1.elb.amazonaws.com/ python3 test.py
...
----------------------------------------------------------------------
Ran 3 tests in 2.146s

OK
```

# Challenge directions

## Infrastructure

For this project, please think about how you would architect a scalable and secure static web application in AWS.

* Create and deploy a running instance of a web server using a configuration management tool of your choice. The web server should serve one page with the following content.

```html
<html>
<head>
<title>Hello World</title>
</head>
<body>
<h1>Hello World!</h1>
</body>
</html>
```

* Secure this application and host such that only appropriate ports are publicly exposed and any http requests are redirected to https. This should be automated using a configuration management tool of your choice and you should feel free to use a self-signed certificate for the web server.
* Develop and apply automated tests to validate the correctness of the server configuration.
* Express everything in code.
* Provide your code in a Git repository named `<FIRSTNAME>_Challenge` on GitHub.com
* Be prepared to walk though your code, discuss your thought process, and talk through how you might monitor and scale this application. You should also be able to demo a running instance of the host.
