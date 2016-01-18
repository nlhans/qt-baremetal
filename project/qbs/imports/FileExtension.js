function FileExtension(filename, skip)
{
	var p = filename.split('.');
	while(skip-- > 0)
		p.pop();
	return p.pop();
}