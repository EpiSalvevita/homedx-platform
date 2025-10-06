import { GraphQLScalarType } from 'graphql';
export declare const GraphQLUpload: GraphQLScalarType<unknown, unknown>;
export declare class UploadResponse {
    success: boolean;
    objectName?: string;
    validation?: string;
}
export declare class Upload {
    filename: string;
    mimetype: string;
    encoding: string;
}
