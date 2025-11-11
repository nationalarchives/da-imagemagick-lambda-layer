#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { DaImagemagickLambdaLayerStack } from '../lib/da-imagemagick-lambda-layer-stack';

const app = new cdk.App();
new DaImagemagickLambdaLayerStack(app, 'DaImagemagickLambdaLayerStack', {
});