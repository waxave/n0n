import {
    IExecuteFunctions,
    INodeExecutionData,
    INodeType,
    INodeTypeDescription,
    NodeConnectionType,
} from 'n8n-workflow';

export class ShortcutApi implements INodeType {
    description: INodeTypeDescription = {
        displayName: 'Shortcut API',
        name: 'shortcutApi',
        group: ['transform'],
        version: 1,
        description: 'Integra con el API de Shortcut',
        defaults: {
            name: 'Shortcut API',
        },
        inputs: ['main'] as NodeConnectionType[],
        outputs: ['main'] as NodeConnectionType[],
        credentials: [
            {
                name: 'shortcutApiToken',
                required: true,
            },
        ],
        properties: [
            {
                displayName: 'Acción',
                name: 'action',
                type: 'options',
                options: [
                    { name: 'Buscar historias', value: 'searchStories' },
                    { name: 'Buscar historias con descripción + comentarios concatenados', value: 'searchStoriesFull' },
                    { name: 'Comentar historia', value: 'commentStory' },
                ],
                default: 'searchStories',
            },
            {
                displayName: 'Query (filtros)',
                name: 'query',
                type: 'string',
                default: '',
                placeholder: 'team:troopers state:unstarted archived:false',
                displayOptions: { show: { action: ['searchStories', 'searchStoriesFull'] } },
            },
            {
                displayName: 'ID Historia',
                name: 'storyId',
                type: 'string',
                default: '',
                description: 'ID de la historia para comentar',
                displayOptions: { show: { action: ['commentStory'] } },
            },
            {
                displayName: 'Texto de comentario',
                name: 'commentText',
                type: 'string',
                default: '',
                description: 'Texto para agregar como comentario',
                displayOptions: { show: { action: ['commentStory'] } },
            },
        ],
    };

    async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
        const items = this.getInputData();
        const returnData: INodeExecutionData[] = [];

        const credentials = await this.getCredentials('shortcutApiToken');
        if (!credentials) {
            throw new Error('Token de Shortcut no encontrado');
        }
        const token = (credentials as { apiToken: string }).apiToken;
        const baseUrl = 'https://api.app.shortcut.com/api/v3';

        const headers = {
            'Shortcut-Token': token,
            'Content-Type': 'application/json',
        };

        const actions: Record<string, (i: number) => Promise<any>> = {
            searchStories: async (i: number) => {
                const query = this.getNodeParameter('query', i) as string;
                const url = `${baseUrl}/search/stories?query=${encodeURIComponent(query)}`;
                const response = await this.helpers.request({ method: 'GET', uri: url, headers, json: true });
                return response.data || [];
            },

            searchStoriesFull: async (i: number) => {
                const query = this.getNodeParameter('query', i) as string;
                const url = `${baseUrl}/search/stories?query=${encodeURIComponent(query)}`;
                const response = await this.helpers.request({ method: 'GET', uri: url, headers, json: true });
                const stories = response.data || [];

                return stories.map((story: any) => {
                    const commentsText = (story.comments || []).map((c: { text: string }) => c.text).join('\n');
                    const fullText = `title: ${story.name || ''}\ndescription: ${story.description || ''}\ncomments: ${commentsText}`;

                    return {
                        ...story,
                        fullText,
                    };
                });
            },

            commentStory: async (i: number) => {
                const storyId = this.getNodeParameter('storyId', i) as string;
                const commentText = this.getNodeParameter('commentText', i) as string;

                if (!storyId) throw new Error('El ID de la historia es requerido para comentar');
                if (!commentText) throw new Error('El texto del comentario no puede estar vacío');

                return await this.helpers.request({
                    method: 'POST',
                    uri: `${baseUrl}/stories/${storyId}/comments`,
                    headers,
                    body: { text: commentText },
                    json: true,
                });
            },
        };

        for (let i = 0; i < items.length; i++) {
            const action = this.getNodeParameter('action', i) as string;
            if (!actions[action]) throw new Error(`Acción no soportada: ${action}`);
            const result = await actions[action](i);
            returnData.push({ json: result });
        }

        return [returnData];
    }
}
