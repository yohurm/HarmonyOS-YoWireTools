import { Subscription } from 'common_core';

import { CommandTemplateRecord } from 'common_storage';

import { KeyValueParam, HttpRequestDraft, HttpResponseRecord } from '../domain/model/HttpModels';

import { WifiNetworkConstants } from '../constants/WifiNetworkConstants';

import {

  ExecuteHttpSessionUseCase,

  ExportHttpExchangeUseCase,

  ListHttpRequestTemplatesUseCase,

  LoadHttpRequestTemplateUseCase,

  SaveHttpRequestTemplateUseCase

} from '../domain/usecase/WifiNetworkSessionUseCases';



@ObservedV2

export class HttpClientViewModel {

  @Trace method: string = 'GET';

  @Trace url: string = 'https://httpbin.org/get';

  @Trace bodyText: string = '';

  @Trace headers: KeyValueParam[] = [new KeyValueParam('User-Agent', 'YoWireTools/1.0')];

  @Trace queryParams: KeyValueParam[] = [];

  @Trace connectTimeoutMs: number = WifiNetworkConstants.DEFAULT_HTTP_TIMEOUT_MS;

  @Trace readTimeoutMs: number = WifiNetworkConstants.DEFAULT_HTTP_TIMEOUT_MS;

  @Trace showBodyEditor: boolean = false;

  @Trace templateName: string = 'My request';

  @Trace templates: CommandTemplateRecord[] = [];

  @Trace exportText: string = '';

  @Trace response: HttpResponseRecord | undefined;

  @Trace sending: boolean = false;

  @Trace statusMessage: string = '';



  private readonly executeHttp: ExecuteHttpSessionUseCase = new ExecuteHttpSessionUseCase();

  private readonly saveTemplate: SaveHttpRequestTemplateUseCase = new SaveHttpRequestTemplateUseCase();

  private readonly listTemplates: ListHttpRequestTemplatesUseCase = new ListHttpRequestTemplatesUseCase();

  private readonly loadTemplate: LoadHttpRequestTemplateUseCase = new LoadHttpRequestTemplateUseCase();

  private readonly exportExchange: ExportHttpExchangeUseCase = new ExportHttpExchangeUseCase();



  buildDraft(): HttpRequestDraft {

    return new HttpRequestDraft(

      `http-${Date.now()}`,

      this.method,

      this.url,

      this.queryParams,

      this.headers,

      this.bodyText,

      this.connectTimeoutMs,

      this.readTimeoutMs,

      WifiNetworkConstants.DEFAULT_HTTP_MAX_BYTES

    );

  }



  async sendAction(): Promise<void> {

    this.sending = true;

    this.statusMessage = 'Sending...';

    const draft = this.buildDraft();

    const result = await this.executeHttp.execute(draft);

    if (result.success && result.value !== undefined) {

      this.response = result.value;

      this.statusMessage = `HTTP ${result.value.responseCode} in ${result.value.latencyMs}ms`;

    } else {

      this.statusMessage = result.error?.message ?? 'Request failed';

    }

    this.sending = false;

  }



  async saveTemplateAction(): Promise<void> {

    const result = await this.saveTemplate.execute(this.templateName, this.buildDraft());

    this.statusMessage = result.success ? 'Template saved' : (result.error?.message ?? 'Save failed');

    if (result.success) {

      await this.refreshTemplates();

    }

  }



  async refreshTemplates(): Promise<void> {

    const result = await this.listTemplates.execute();

    if (result.success && result.value !== undefined) {

      this.templates = result.value;

    }

  }



  async applyTemplate(record: CommandTemplateRecord): Promise<void> {

    const result = await this.loadTemplate.execute(record);

    if (!result.success || result.value === undefined) {

      this.statusMessage = result.error?.message ?? 'Load template failed';

      return;

    }

    const draft = result.value;

    this.method = draft.method;

    this.url = draft.url;

    this.queryParams = draft.queryParams;

    this.headers = draft.headers;

    this.bodyText = draft.bodyText;

    this.connectTimeoutMs = draft.connectTimeoutMs;

    this.readTimeoutMs = draft.readTimeoutMs;

    this.statusMessage = `Loaded template ${record.name}`;

  }



  exportLastExchange(): void {

    const result = this.exportExchange.execute(this.buildDraft(), this.response);

    if (result.success && result.value !== undefined) {

      this.exportText = result.value;

      this.statusMessage = 'Exchange exported to text area';

    }

  }

}

