module StatsCol;

global g_uid: string;  # global variable to store the unit id

global dnp3_start: time;
global total_time: interval = 0sec;
global total_count: count = 0;

# Get the additional addresses from the header
event dnp3_header_block(c: connection, is_orig: bool, start: count, len: count, ctrl: count, dest_addr: count, src_addr: count)
{
    dnp3_start = current_time();
    g_uid = cat(src_addr, ":", dest_addr);
}

# Get the DNP3 protocol name and the function code from the dnp3 application request header
event dnp3_application_request_header(c: connection, is_orig: bool, application: count, fc: count)
{
    local ts: time = network_time();
    local fn: string = DNP3::function_codes[fc];
    event ProtocolLevel::protocol_get([$ts=ts, $conn=c, $protocol="DNP3", $uid=g_uid, $fc=fc, $fn=fn, $is_orig=is_orig]);
    total_time += current_time() - dnp3_start;
    total_count += 1;
}

# Get the DNP3 protocol name and the function code from the dnp3 application response header
event dnp3_application_response_header(c: connection, is_orig: bool, application: count, fc: count, iin: count)
{
    local ts: time = network_time();
    local fn: string = DNP3::function_codes[fc];
    event ProtocolLevel::protocol_get([$ts=ts, $conn=c, $protocol="DNP3", $uid=g_uid, $fc=fc, $fn=fn, $is_orig=is_orig]);
    total_time += current_time() - dnp3_start;
    total_count += 1;
}

event bro_done()
{
    local dnp3_time: interval = total_time / total_count;
    print fmt("DNP3_bro: %s", dnp3_time);
}