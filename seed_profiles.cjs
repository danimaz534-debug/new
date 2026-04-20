const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://hqszihvjqscrwdzrwbyg.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NzA4NzksImV4cCI6MjA5MTA0Njg3OX0.Oe6Jm4dduicJRhF_cGol7lLjWD3W5nNUiJqSvbhnaII';

const supabase = createClient(supabaseUrl, supabaseKey);

const users = [
  { id: '195c0592-bfb3-4b12-a9c9-8807e5cd0e4b', email: 'admin_test_123@example.com', full_name: null, role: 'admin' },
  { id: '2fd59a00-f8fa-4376-8b65-903175c8f895', email: 'admin@email.com', full_name: null, role: 'admin' },
  { id: 'ccd2538b-fb10-4577-8f78-61be1789254', email: 'danimaz534@gmail.com', full_name: 'Dani', role: 'admin' },
  { id: '02082d0b-d352-4637-ad37-3b199d3f8355', email: 'marketing@email.com', full_name: null, role: 'marketing' },
  { id: 'f7ade1f6-4af8-4ed5-b3ec-ec1bd6da6122', email: 'mnawerenta@gmail.com', full_name: 'Mhmd', role: 'admin' },
  { id: 'd47b4986-4150-4686-8a9b-8a9239f88d60', email: 'sales@email.com', full_name: null, role: 'sales' },
];

async function seedProfiles() {
  for (const user of users) {
    try {
      const { data, error } = await supabase.rpc('ensure_profile', {
        p_full_name: user.full_name,
        p_role: user.role,
        p_language: 'en',
      });

      if (error) {
        console.error(`Error for ${user.email}:`, error);
      } else {
        console.log(`Profile created for ${user.email}:`, data);
      }
    } catch (err) {
      console.error(`Failed for ${user.email}:`, err);
    }
  }
}

seedProfiles();