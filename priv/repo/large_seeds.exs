1..5_000_000
|> Enum.map(fn i ->
  time = DateTime.add(DateTime.utc_now(), i * 10, :second)

  %{
    id: UXID.generate!(prefix: "chk"),
    status: :success,
    status_code: 200,
    response_body: "Hello, world!",
    dns_time: 10,
    connect_time: 20,
    tls_time: 30,
    first_byte_time: 40,
    request_time: 100,
    service_id: "1",
    inserted_at: time,
    updated_at: time
  }
end)
|> Enum.chunk_every(1000)
|> Enum.each(&Uptime.Repo.insert_all(Uptime.Check, &1))
