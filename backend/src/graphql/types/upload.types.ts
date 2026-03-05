import { Field, ObjectType, registerEnumType } from '@nestjs/graphql';
import { GraphQLScalarType } from 'graphql';

export const GraphQLUpload = new GraphQLScalarType({
  name: 'Upload',
  description: 'The `Upload` scalar type represents a file upload.',
  parseValue: (value) => value,
  serialize: (value) => value,
  parseLiteral: (ast) => ast,
});

@ObjectType()
export class UploadResponse {
  @Field()
  success: boolean;

  @Field({ nullable: true })
  objectName?: string;

  @Field({ nullable: true })
  validation?: string;
}

@ObjectType()
export class Upload {
  @Field()
  filename: string;

  @Field()
  mimetype: string;

  @Field()
  encoding: string;
} 