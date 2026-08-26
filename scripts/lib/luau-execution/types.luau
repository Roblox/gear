-- `output` and `error` are mutually exclusive: a task only carries results once
-- it reaches a terminal successful state.
export type LuauTaskResponse = {
	binaryInput: string,
	binaryOutputUri: string,
	createTime: string,
	enableBinaryOutput: boolean,
	output: {
		results: { any },
	}?,
	path: string,
	script: string,
	state: string,
	updateTime: string,
	user: string,
	error: { [string]: any }?,
}

return {}
