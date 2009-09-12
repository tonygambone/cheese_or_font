#
# load cheeses and fonts files into the database
# run with script/runner
#
# does not delete current database items, just adds new ones
#
{'cheeses.txt'=>true, 'fonts.txt'=>false}.each do |file, is_cheese|
  File.open(File.join(Rails.root, 'db', file)).each_line do |line|
    begin
      Item.new(:name=>line.strip, :cheese=>is_cheese).save  
      puts line.strip      
    rescue
      # ignore unique index errors
    end
  end
end
