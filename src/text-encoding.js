export function toDecoded(byte) {
    if(0xBB <= byte && byte <= 0xD4) {
        return String.fromCharCode('A'.charCodeAt(0) + (byte - 0xBB));
    }

    if(0xD5 <= byte && byte <= 0xEE) {
        return String.fromCharCode('a'.charCodeAt(0) + (byte - 0xD5));
    }

    if(0xA1 <= byte && byte <= 0xAA) {
        return String.fromCharCode('0'.charCodeAt(0) + (byte - 0xA1));
    }

    return ' ';
}

export function decode(buffer, maxLength = Infinity) {
    const symbols = [];

    for(let i = 0; i < Math.min(buffer.length, maxLength); i++) {
        const symbol = buffer.readUInt8(i);

        if(symbol === 0xFF) break;

        symbols.push(symbol);
    }

    return symbols.map(toDecoded).join('');
}
