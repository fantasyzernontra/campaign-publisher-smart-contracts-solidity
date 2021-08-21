const path = require('path')
const solc = require('solc')
const fs = require('fs-extra')

// Deletes existed build directory.
const buildPath = path.resolve(__dirname, 'build')
fs.removeSync(buildPath)

// Reads Campaign contract.
const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol')
const source = fs.readFileSync(campaignPath, 'utf-8')

// Gets contract's abi.
const output = solc.compile(source, 1).contracts

fs.ensureDirSync(buildPath)

// Creates an output folder.
for (let contract in output) {
	fs.outputJsonSync(
		path.resolve(buildPath, contract.replace(':', '') + '.json'),
		output[contract]
	)
}
