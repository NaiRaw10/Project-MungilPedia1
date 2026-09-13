import express from "express";
import cors from "cors";
import db from "./index.js";
import { z } from "zod";
import path from "path";
import { fileURLToPath } from "url";

// Konfigurasi __dirname untuk ES Module (import)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const categorySchema = z.object({
  namaKategori: z
    .string({
      required_error: "Nama kategori wajib diisi",
    })
    .min(3, { message: "Nama kategori minimal 3 karakter" }),
});

const postSchema = z.object({
  kategoriId: z
    .number({
      required_error: "kategoriId wajib diisi",
    })
    .int()
    .positive({ message: "kategoriId harus berupa angka positif" }),
  judul: z
    .string({
      required_error: "Judul wajib diisi",
    })
    .min(1, { message: "Judul tidak boleh kosong" }),
  deskripsi: z
    .string({
      required_error: "Deskripsi wajib diisi",
    })
    .min(1, { message: "Deskripsi tidak boleh kosong" }),
  karakteristik: z.string().optional(),
  gambar: z.string().optional(),
});

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Menyediakan folder uploads sebagai static folder
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

app.get("/api/categories", async (req, res) => {
  try {
    const [rows] = await db.query("select * from categories");
    return res.status(200).json({
      status: "success",
      message: "Berhasil mengambil daftar kategori",
      data: rows,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      message: "Terjadi kesalahan pada server",
      error: error.message,
    });
  }
});

// GET /api/posts (DENGAN DUKUNGAN FILTER KATEGORI)
app.get("/api/posts", async (req, res) => {
  try {
    // Tangkap query parameter dari URL (bisa kategori_id atau kategoriId)
    const categoryId = req.query.kategori_id || req.query.kategoriId;

    let querySQL = "SELECT * FROM posts";
    let params = [];

    // Jika ada parameter kategori yang dikirim, tambahkan klausa WHERE
    if (categoryId) {
      querySQL += " WHERE kategoriId = ?"; // Sesuaikan nama kolom jika di DB MySQL kamu 'kategori_id'
      params.push(categoryId);
    }

    const [rows] = await db.query(querySQL, params);

    return res.status(200).json({
      status: "success",
      message: "Berhasil mengambil daftar postingan",
      data: rows,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      message: "Terjadi kesalahan pada server",
      error: error.message,
    });
  }
});

app.post("/api/posts", async (req, res) => {
  const parseResult = postSchema.safeParse(req.body);

  if (!parseResult.success) {
    return res.status(400).json({
      status: "fail",
      message: "Validasi data artikel gagal",
      errors: parseResult.error.flatten().fieldErrors,
    });
  }

  const { kategoriId, judul, deskripsi, karakteristik, gambar } =
    parseResult.data;

  try {
    const querySQL = `
      INSERT INTO posts (kategoriId, judul, deskripsi, karakteristik, gambar)
      VALUES (?, ?, ?, ?, ?)
    `;
    const [result] = await db.query(querySQL, [
      kategoriId,
      judul,
      deskripsi,
      karakteristik || null,
      gambar || null,
    ]);

    return res.status(201).json({
      status: "success",
      message: "Artikel berhasil ditambahkan",
      data: {
        id: result.insertId,
        kategoriId,
        judul,
        deskripsi,
        karakteristik,
        gambar,
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      message: "Terjadi kesalahan pada server",
      error: error.message,
    });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});