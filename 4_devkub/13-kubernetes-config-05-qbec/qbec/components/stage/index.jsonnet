
local pvstage = import "./pv-stage.jsonnet";
local front = import './front.jsonnet';
local back = import './back.jsonnet';
local psql = import './psql.jsonnet';
{
call_pvstage: pvstage(),
call_front: front(),
call_back: back(),
call_psql: psql()
}
