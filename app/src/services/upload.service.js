// Upload service for handling file uploads without apollo-upload-client
const GRAPHQL_URL = process.env.GRAPHQL_URL || 'http://localhost:4000/graphql';

export const uploadFile = async (file, mutation, variables = {}) => {
  const token = localStorage.getItem('auth_token');
  
  try {
    // Create FormData with the file and variables
    const formData = new FormData();
    
    // Add the GraphQL query
    formData.append('operations', JSON.stringify({
      query: mutation,
      variables: {
        ...variables,
        file: null // This will be replaced by the file
      }
    }));
    
    // Map the file to the correct variable
    formData.append('map', JSON.stringify({
      '0': ['variables.file']
    }));
    
    // Add the file
    formData.append('0', file);

    const response = await fetch(GRAPHQL_URL, {
      method: 'POST',
      headers: {
        'Authorization': token ? `Bearer ${token}` : '',
        'x-apollo-operation-name': 'UploadFile',
        'apollo-require-preflight': 'true'
      },
      body: formData
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('HTTP error response:', errorText);
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    
    if (result.errors) {
      console.error('GraphQL errors:', result.errors);
      throw new Error(result.errors[0].message);
    }

    return result.data;
  } catch (error) {
    console.error('Upload error:', error);
    throw error;
  }
};

export const uploadTestPhoto = async (file, fileExtension = 'jpeg') => {
  const mutation = `
    mutation UploadTestPhoto($file: Upload!, $fileExtension: String!) {
      uploadTestPhoto(file: $file, fileExtension: $fileExtension) {
        success
        objectName
      }
    }
  `;
  
  const result = await uploadFile(file, mutation, { fileExtension });
  return result.uploadTestPhoto;
};

export const uploadTestVideo = async (file, fileExtension = 'mp4', head, headpre) => {
  const mutation = `
    mutation UploadTestVideo($file: Upload!, $fileExtension: String!, $head: String, $headpre: String) {
      uploadTestVideo(file: $file, fileExtension: $fileExtension, head: $head, headpre: $headpre) {
        success
        objectName
        validation
      }
    }
  `;
  
  const result = await uploadFile(file, mutation, { fileExtension, head, headpre });
  return result.uploadTestVideo;
}; 