import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import {Code, LayerVersion, Runtime} from "aws-cdk-lib/aws-lambda";
import * as path from "node:path";
import {CfnOutput} from "aws-cdk-lib";

export class DaImagemagickLambdaLayerStack extends cdk.Stack {
    constructor(scope: Construct, id: string, props: cdk.StackProps = {}) {
        super(scope, id);

        const layerVersion = new LayerVersion(this, "imagemagick", {
            code: Code.fromAsset(path.join(__dirname, "../package.zip")),
            compatibleRuntimes: [Runtime.NODEJS_22_X],
            description: "Layer created from zip (see Dockerfile for recipe)"
        })

        new CfnOutput(this, "LayerVersionOutput", {
            value: layerVersion.layerVersionArn,
            description: "The arn of the lambda layer",
            exportName: "layerArn",
        });
    }
}
