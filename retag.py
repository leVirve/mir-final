
tag_set = set()
sgmts = []

with open('annotations/AIST.RWC-MDB-P-2001.CHORUS/RM-P001.CHORUS.TXT') as f:
	for line in f:
		s, e, tag = line.strip().split('\t')
		s, e = float(s) / 100, float(e) / 100
		tag_set.add(tag)
		sgmts.append((s, e, tag))

tags = list(tag_set)

results = []
for sgmt in sgmts:
	results.append((sgmt[0], sgmt[1], chr(tags.index(sgmt[2]) + ord('A'))))

with open('rwc01.txt', 'w') as f:
	for r in results:
		f.write('%f\t%f\t%s\n' % (r[0], r[1], r[2]))
