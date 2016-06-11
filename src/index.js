import fs from 'fs';
import util from 'util';

import getBlocks from './blocks';
import readGameSave from './game-save';

const blocks = getBlocks(
    fs.readFileSync(process.argv[2] || 'FireRed-Ray2.sav')
);

const currentBlock = blocks[0];

const saveData = readGameSave(currentBlock);

console.log(
    util.inspect(
        saveData,
        { depth: null }
    )
);
