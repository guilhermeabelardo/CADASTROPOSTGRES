using System;
using System.Windows.Forms;
using Npgsql;

namespace CadastroPostgres
{
    public partial class Form1 : Form
    {
        string connString = "Host=localhost;Port=5432;Username=postgres;Password=materiaprima1;Database=teste_dev";
        int selectedId = -1;

        public Form1() => InitializeComponent();

        private void Form1_Load(object sender, EventArgs e)
        {
            CarregarDados();
        }

        private void CarregarDados()
        {
            try
            {
                using var conn = new NpgsqlConnection(connString);
                conn.Open();
                string sql = "SELECT id, campo_texto, campo_numerico FROM cadastro ORDER BY id";
                using var da = new NpgsqlDataAdapter(sql, conn);
                var dt = new System.Data.DataTable();
                da.Fill(dt);
                dataGridView1.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Erro ao carregar dados: " + ex.Message);
            }
        }

        private bool ValidarEntradas(out string texto, out int numero)
        {
            texto = txtTexto.Text.Trim();
            if (string.IsNullOrWhiteSpace(texto))
            {
                MessageBox.Show("O campo de texto não pode estar vazio.");
                numero = 0;
                return false;
            }

            if (!int.TryParse(txtNumero.Text.Trim(), out numero) || numero <= 0)
            {
                MessageBox.Show("Digite um número inteiro válido e maior que zero.");
                return false;
            }

            return true;
        }

        private void btnInserir_Click(object sender, EventArgs e)
        {
            if (!ValidarEntradas(out string texto, out int numero)) return;

            try
            {
                using var conn = new NpgsqlConnection(connString);
                conn.Open();
                string sql = "INSERT INTO cadastro (campo_texto, campo_numerico) VALUES (@texto, @numero)";
                using var cmd = new NpgsqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("texto", texto);
                cmd.Parameters.AddWithValue("numero", numero);
                cmd.ExecuteNonQuery();
                CarregarDados();
                LimparCampos();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Erro ao inserir: " + ex.Message);
            }
        }

        private void btnAtualizar_Click(object sender, EventArgs e)
        {
            if (selectedId == -1)
            {
                MessageBox.Show("Selecione um registro para atualizar.");
                return;
            }

            if (!ValidarEntradas(out string texto, out int numero)) return;

            try
            {
                using var conn = new NpgsqlConnection(connString);
                conn.Open();
                string sql = "UPDATE cadastro SET campo_texto = @texto, campo_numerico = @numero WHERE id = @id";
                using var cmd = new NpgsqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("texto", texto);
                cmd.Parameters.AddWithValue("numero", numero);
                cmd.Parameters.AddWithValue("id", selectedId);
                cmd.ExecuteNonQuery();
                CarregarDados();
                LimparCampos();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Erro ao atualizar: " + ex.Message);
            }
        }

        private void btnExcluir_Click(object sender, EventArgs e)
        {
            if (selectedId == -1)
            {
                MessageBox.Show("Selecione um registro para excluir.");
                return;
            }

            if (MessageBox.Show("Tem certeza que deseja excluir este registro?",
                "Confirmação", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No)
            {
                return;
            }

            try
            {
                using var conn = new NpgsqlConnection(connString);
                conn.Open();
                string sql = "DELETE FROM cadastro WHERE id = @id";
                using var cmd = new NpgsqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("id", selectedId);
                cmd.ExecuteNonQuery();
                CarregarDados();
                LimparCampos();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Erro ao excluir: " + ex.Message);
            }
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                selectedId = Convert.ToInt32(dataGridView1.Rows[e.RowIndex].Cells["id"].Value);
                txtTexto.Text = dataGridView1.Rows[e.RowIndex].Cells["campo_texto"].Value.ToString();
                txtNumero.Text = dataGridView1.Rows[e.RowIndex].Cells["campo_numerico"].Value.ToString();
            }
        }

        private void LimparCampos()
        {
            txtTexto.Clear();
            txtNumero.Clear();
            selectedId = -1;
        }
    }
}
