<h1>Statistics</h1>
<p>
<?php
require_once('db.php');
require_once('common.php');

$stats = array();
$sql = 'SELECT * FROM stats';
$stmt = $mysql->stmt_init();
$stmt->prepare($sql);
$data = array();
stmt_bind_assoc($stmt, $data);
$stmt->execute();

while ($stmt->fetch())
    $stats[$data['pname']] = $data['pvalue'];
$stmt->close();
$mysql->close();

echo "Total nets: {$stats['nets']} / {$stats['nets_unc']} unique<br/>\n";
echo "Cracked nets: {$stats['cracked']} / {$stats['cracked_unc']} unique<br/>\n";
if ((int) $stats['nets'] > 0) {
    $srate = round((int) $stats['cracked'] / (int) $stats['nets'] * 100, 2);
    $srate_unc = round((int) $stats['cracked_unc'] / (int) $stats['nets_unc'] * 100, 2);
    echo "Success rate: $srate% / $srate_unc% unique<br/>\n";
}
echo "Last day getworks: {$stats['24getwork']}<br/>\n";
$perf = convert_num($stats['24psk']/(60*60*24));
echo "Last day performance: $perf/s<br/>\n";
echo "Last day submissions: {$stats['24sub']}<br/>\n";
echo "Current round ends in: ";
if ((int) $stats['24psk'] > 0)
    echo convert_sec(round(((int) $stats['words'] - (int) $stats['triedwords']) / ((int) $stats['24psk']/(60*60*24))));
else
    echo 'infinity';
echo "<br/>\n";
?>
<br/>
Current keyspace progress:
<dl class="progress">
    <dd class="done" style="width: <?php echo round((int) $stats['triedwords'] / (int) $stats['words'] * 100); ?>%"><?php echo round((int) $stats['triedwords'] / (int) $stats['words'] * 100, 2); ?>%</dd>
</dl>
</p>
