import fs from 'fs';
let c = fs.readFileSync('supabase/config.toml', 'utf8');
c = c.replace('env(GOOGLE_CLIENT_ID)', '1046087495737-vs9gungsu9rbc0673rtr8kk8om7rv6fc.apps.googleusercontent.com');
c = c.replace('env(GOOGLE_CLIENT_SECRET)', 'GOCSPX-PLACEHOLDER_REPLACE_WITH_SECRET');
fs.writeFileSync('supabase/config.toml', c);
console.log('Updated config.toml');
