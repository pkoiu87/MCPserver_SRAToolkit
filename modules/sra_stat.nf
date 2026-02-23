process SRA_STAT {
    tag "${sample_id}"; label 'process_low'
    publishDir "${params.outputFilePath}", mode: 'copy'
    input: tuple val(sample_id), path(sra_file)
    output: path "${sample_id}.stat.jsonl"; path "${sample_id}_stats.xml"
    script:
    """
    sra-stat -x -s ${sra_file} > ${sample_id}_stats.xml
    python3 <<EOF
import xml.etree.ElementTree as ET
import json, os
tree = ET.parse('${sample_id}_stats.xml')
root = tree.getroot()
stats_elem = root.find('.//Statistics')
nspots = int(stats_elem.get('nspots', 0))
bases_elem = root.find('.//Bases')
total_bases = int(bases_elem.get('count', 1))
cg_count = sum(int(b.get('count', 0)) for b in bases_elem.findall('Base') if b.get('value') in ['C', 'G'])
gc_content = round((cg_count / total_bases) * 100, 2)
def get_rs(idx):
    r = root.find(f".//Read[@index='{idx}']")
    return (r.get('average', '0'), r.get('stdev', '0')) if r is not None else ("0", "0")
avg_r1, std_r1 = get_rs(0)
avg_r2, std_r2 = get_rs(1)
report = {
    "Run accession": "${params.outputFileNm}",
    "spot_count": f"{nspots:,}", "spot_count_mates": f"{nspots:,}",
    "base_count": f"{total_bases:,}", "Size value": f"{round(os.path.getsize('${sra_file}')/(1024*1024),2)} MB",
    "GC Content": f"{gc_content} %", "Average_R1": avg_r1, "Stdev_R1": std_r1,
    "Average_R2": avg_r2, "Stdev_R2": std_r2
}
with open('${sample_id}.stat.jsonl', 'w') as f:
    f.write(json.dumps(report) + '\\n')
EOF
    """
}
