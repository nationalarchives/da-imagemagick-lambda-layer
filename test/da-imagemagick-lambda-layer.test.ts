import * as cdk from 'aws-cdk-lib';
import { Template } from 'aws-cdk-lib/assertions';
import * as DaImagemagickLambdaLayer from '../lib/da-imagemagick-lambda-layer-stack';

test('Layer Version Created', () => {
  const app = new cdk.App();
  const stack = new DaImagemagickLambdaLayer.DaImagemagickLambdaLayerStack(app, 'MyTestStack');
  const template = Template.fromStack(stack);

  template.hasResourceProperties('AWS::Lambda::LayerVersion', {
    CompatibleRuntimes: ["nodejs22.x"]
  });
});
