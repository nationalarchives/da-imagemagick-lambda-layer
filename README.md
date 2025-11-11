# ImageMagick lambda layer

![Tests](https://github.com/nationalarchives/da-imagemagick-lambda-layer/actions/workflows/test.yml/badge.svg)
![Licence](https://img.shields.io/badge/Licence-Crown_Copyright-blue)

This creates a lambda layer with ImageMagick installed. It allows ImageMagick commands to be run in the lambda.

The layer is built using docker and deployed using cdk.

## Usage

### Build the zip package
To build the zip package. This will output a zip file called `package.zip` at the root of the repository.

```bash
./run.sh build
```

### Deploy the zip package

```bash
./run.sh deploy
```

To deploy the zip package without an approval step.

```bash
./run.sh deploy -y
```

This will check if there is an existing package.zip in the root of the repository. If there is, it will deploy that. 
If not, it will run the build command first.

The command will output the layer version arn.

### Destroy the lambda layer

```bash
./run.sh destroy
```

### Get the layer version arn

```bash
./run.sh arn
```

## Run the tests
```bash
npm t
```