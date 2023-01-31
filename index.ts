import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";

// TODO: generate new IAM to CI builder role
const web = new aws.ec2.Instance("maci-builder", {
    ami: "ami-08d487b452907cccd",
    instanceType: "t2.micro",
    tags: {
        Name: "maci-builder",
    },
    vpcSecurityGroupIds: ["sg-0aea3cbb15e30a921"],
    subnetId: "subnet-0817be1b2160793b5",
    associatePublicIpAddress: true,
    keyName: "maci-devops",
    rootBlockDevice: {
        volumeSize: 50,
        volumeType: "gp3"
    }
});


export const publicIp = web.publicIp
export const instanceId = web.id
