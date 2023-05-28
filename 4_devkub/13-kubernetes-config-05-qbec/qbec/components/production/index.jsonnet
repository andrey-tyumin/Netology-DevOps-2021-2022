local pvprod = import "./pv-prod.jsonnet";
local front = import './front.jsonnet';
local back = import './back.jsonnet';
local psql = import './psql.jsonnet';
local endpoint = import './endpoint.jsonnet';
{
call_pvprod: pvprod(),
call_front: front(),
call_back: back(),
call_psql: psql(),
call_endpoint: endpoint()
}