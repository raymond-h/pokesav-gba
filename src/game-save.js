import { decode } from './text-encoding';
import { section1Offsets } from './game-specific-info';
import readPokemon from './pokemon-data';

function readGameAndSecurityKey(section) {
    const gameCode = section.readUInt32LE(0xAC);

    if(gameCode === 0) {
        return ['rubySapphire', 0x00];
    }
    else if(gameCode === 1) {
        return ['fireRedLeafGreen', section.readUInt32LE(0x0AF8)];
    }
    else {
        return ['emerald', gameCode];
    }
}

function readPlaytime(buffer) {
    const hours = buffer.readUInt16LE(0);
    const minutes = buffer.readUInt8(2);
    const seconds = buffer.readUInt8(3);
    const frames = buffer.readUInt8(4);

    return (frames/60 + seconds + 60*minutes + 60*60*hours) * 1000;
}

function readParty(buffer, count) {
    const party = [];

    for(let i = 0; i < count; i++) {
        const pokeStart = buffer.slice(i*100);

        party.push(readPokemon(pokeStart, true));
    }

    return party;
}

function getPcBuffer(sections) {
    const bufferParts = [];

    for(let i = 5; i <= 13; i++) {
        bufferParts.push(
            sections[i].slice(0, (i === 13) ? 2000 : 3968)
        );
    }

    return Buffer.concat(bufferParts);
}

export default function readGameSave(block) {
    const [game, securityKey] = readGameAndSecurityKey(block.sections[0]);
    const s1Offsets = section1Offsets[game];

    return {
        name: decode(block.sections[0].slice(0x00), 7),
        gender: block.sections[0].readUInt8(0x08) ? 'female' : 'male',
        totalPlaytime: readPlaytime(block.sections[0].slice(0x0E)),

        party: readParty(
            block.sections[1].slice(s1Offsets.teamStart),
            block.sections[1].readUInt32LE(s1Offsets.teamSize)
        ),
        money: (block.sections[1].readUInt32LE(s1Offsets.money) ^ securityKey) & 0xFFFF,

        _pcBuffer: getPcBuffer(block.sections)
    };
}
