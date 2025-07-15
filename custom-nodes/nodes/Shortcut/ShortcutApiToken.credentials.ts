import { ICredentialType, INodeProperties } from 'n8n-workflow';

export class ShortcutApiToken implements ICredentialType {
    name = 'shortcutApiToken';
    displayName = 'Shortcut API Token';
    documentationUrl = 'https://developer.shortcut.com/api/rest/v3';
    properties: INodeProperties[] = [
        {
            displayName: 'API Token',
            name: 'apiToken',
            type: 'string',
            default: '',
        },
    ];
}