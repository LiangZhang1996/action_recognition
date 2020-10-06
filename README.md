## Dataset
`hmdb51`
## 思路：
	使用训练好的googlenet，提取video每一帧feature，然后再组合成sequence数据；训练netLSTM； 拆分组合googlenet和netLSTM， 生成net， net可以直接识别视频数据。


## files：
	
	hmdb51Files.m	获取文件夹文件名，并产生label
	
	readVideo.m	读取video

	centerCrop.m	resize video
		

	testVideo.m	读取文件夹内 video, 确保video可读，没有问题
	
	trainNet.m	训练网络 netLSTM, 
	
	AssembleNet.m	组合netLSTM和googlenet, 生成net， 使其可以直接识别video

	test.m		读入一个 video， 使用net 测试


## 注意：
	1. 确定每个video可以成功读取

	2. trainNet.m中读video并使用googlenet计算feature时，耗时太长，最好选几个动作训练识别，而不是所有，否则时间太长

	3. 最后组合好的 net可以保存，下次之际导入，用于测试识别效果。