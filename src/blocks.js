import _ from 'lodash';

function getSectionSaveId(sectionBuffer) {
    return sectionBuffer.readUInt32LE(0x0FFC);
}

function reorderSections(sections) {
    return _.sortBy(sections,
        section => section.readUInt16LE(0x0FF4)
    );
}

function determineSections(buffer) {
    const sections = [];

    for(let i = 0; i < 14; i++) {
        sections.push(buffer.slice(i*4096, i*4096 + 4096));
    }

    return {
        saveId: getSectionSaveId(sections[0]),
        sections: reorderSections(sections)
    };
}

function reorderBlocks(blocks) {
    return _.sortBy(blocks, block => -block.saveId);
}

export default function getBlocks(buffer) {
    return reorderBlocks(
        [
            buffer.slice(0, 57344),
            buffer.slice(57344, 2*57344)
        ]
        .map(determineSections)
    );
}
