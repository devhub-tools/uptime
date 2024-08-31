defmodule DevhubProtos.Uptime.V1.CheckRequest do
  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :url, 1, type: :string
  field :method, 2, type: :string
end

defmodule DevhubProtos.Uptime.V1.CheckResponse do
  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :dns, 1, type: :int32
  field :connect, 2, type: :int32
  field :tls, 3, type: :int32
  field :first_byte, 4, type: :int32, json_name: "firstByte"
  field :complete, 5, type: :int32
  field :status_code, 6, type: :int32, json_name: "statusCode"
  field :response_body, 7, type: :bytes, json_name: "responseBody"
end

defmodule DevhubProtos.Uptime.V1.UptimeService.Service do
  use GRPC.Service, name: "uptime.v1.UptimeService", protoc_gen_elixir_version: "0.12.0"

  rpc :Check, DevhubProtos.Uptime.V1.CheckRequest, DevhubProtos.Uptime.V1.CheckResponse
end

defmodule DevhubProtos.Uptime.V1.UptimeService.Stub do
  use GRPC.Stub, service: DevhubProtos.Uptime.V1.UptimeService.Service
end