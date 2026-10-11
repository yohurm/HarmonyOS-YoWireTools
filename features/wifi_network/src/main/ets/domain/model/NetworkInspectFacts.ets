export class NetworkRouteFact {
  readonly destination: string;
  readonly gateway: string;
  readonly isDefault: boolean;

  constructor(destination: string, gateway: string, isDefault: boolean) {
    this.destination = destination;
    this.gateway = gateway;
    this.isDefault = isDefault;
  }
}

export class NetworkPropertyFacts {
  readonly interfaceName: string;
  readonly mtu: string;
  readonly routes: NetworkRouteFact[];
  readonly linkAddressState: string;
  readonly dnsState: string;
  readonly routeState: string;
  readonly familyLine: string;

  constructor(
    interfaceName: string,
    mtu: string,
    routes: NetworkRouteFact[],
    linkAddressState: string,
    dnsState: string,
    routeState: string,
    familyLine: string
  ) {
    this.interfaceName = interfaceName;
    this.mtu = mtu;
    this.routes = routes;
    this.linkAddressState = linkAddressState;
    this.dnsState = dnsState;
    this.routeState = routeState;
    this.familyLine = familyLine;
  }
}

export class DnsLookupFacts {
  readonly unicodeHost: string;
  readonly asciiHost: string;
  readonly addresses: string[];
  readonly familyLabel: string;

  constructor(unicodeHost: string, asciiHost: string, addresses: string[], familyLabel: string) {
    this.unicodeHost = unicodeHost;
    this.asciiHost = asciiHost;
    this.addresses = addresses;
    this.familyLabel = familyLabel;
  }
}

export class TraceHopFact {
  readonly jumpNo: number;
  readonly address: string;
  readonly rttText: string;

  constructor(jumpNo: number, address: string, rttText: string) {
    this.jumpNo = jumpNo;
    this.address = address;
    this.rttText = rttText;
  }
}

export class ProbeFacts {
  readonly lossRate: string;
  readonly rttText: string;
  readonly methodLabel: string;

  constructor(lossRate: string, rttText: string, methodLabel: string) {
    this.lossRate = lossRate;
    this.rttText = rttText;
    this.methodLabel = methodLabel;
  }
}

export class HttpProxyFacts {
  readonly host: string;
  readonly port: string;
  readonly exclusionList: string;

  constructor(host: string, port: string, exclusionList: string) {
    this.host = host;
    this.port = port;
    this.exclusionList = exclusionList;
  }
}
