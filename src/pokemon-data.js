import _ from 'lodash';

import { decode } from './text-encoding';

function blockOrder(personalityValue) {
    const orderValue = personalityValue % 24;

    const baseOrder = [0, 1, 2, 3];
    const order = [];

    for(const i of [Math.floor(orderValue / 6), Math.floor((orderValue % 6) / 2), orderValue % 2]) {
        order.push(baseOrder[i]);
        _.pullAt(baseOrder, i);
    }

    order.push(baseOrder[0]);

    return order;
}

function invertOrder(order) {
    const outOrder = new Array(order.length);

    order.forEach((index, i) => {
        outOrder[index] = i;
    });

    return outOrder;
}

function reorderBlocks(personalityValue, blocks) {
    const order = invertOrder(
        blockOrder(personalityValue)
    );

    return order.map(i => blocks[i]);
}

function decryptData(key, buffer) {
    for(let i = 0; i < buffer.length; i += 4) {
        const inVal = buffer.readInt32LE(i);
        const outVal = inVal ^ key;
        buffer.writeInt32LE(outVal & 0xFFFFFFFF, i);
    }
}

function getPokemonBlocks(personalityValue, originalTrainerId, buffer) {
    const decryptedBuffer = new Buffer(buffer);
    decryptData(originalTrainerId ^ personalityValue, buffer);

    const blocks = reorderBlocks(
        personalityValue,
        [0, 1, 2, 3].map(i => decryptedBuffer.slice(i*12, i*12 + 12))
    );

    return blocks;
}

function decodePokemonBuffer(buffer) {
    const personalityValue = buffer.readUInt32LE(0x00);
    const originalTrainerId = buffer.readUInt32LE(0x04);

    const blocks = getPokemonBlocks(personalityValue, originalTrainerId, buffer.slice(0x20, 0x20 + 48));

    const outBuffer = new Buffer(buffer);

    blocks.forEach((block, i) => {
        block.copy(outBuffer, 0x20 + i*12);
    });

    return outBuffer;
}

export default function readPokemon(buffer, includeBattleStats = false) {
    const data = decodePokemonBuffer(buffer);

    const personalityValue = data.readUInt32LE(0x00);
    const checksum = data.readUInt16LE(0x1C);

    return {
        personalityValue,
        name: decode(data.slice(0x08), 10),

        experience: data.readUInt32LE(0x20 + 0x04),
    };
}
