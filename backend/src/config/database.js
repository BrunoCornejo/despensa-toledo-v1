import mysql from "mysql2/promise"
import dotenv from "dotenv"

dotenv.config()

const dbConfig = {
  host: process.env.DB_HOST || "localhost",
  port: Number.parseInt(process.env.DB_PORT || "3306"),
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "sistema_ventas2",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  connectTimeout: 10000,
  timezone: "Z",
}

// Validar que las variables estén configuradas
if (!dbConfig.host || !dbConfig.database) {
  console.error("❌ Error: Variables de entorno de base de datos no están definidas correctamente.")
  console.error("💡 Asegúrate de tener configurado en tu .env:")
  console.error("   DB_HOST=localhost")
  console.error("   DB_PORT=3306")
  console.error("   DB_USER=root")
  console.error("   DB_PASSWORD=")
  console.error("   DB_NAME=sistema_ventas2")
  process.exit(1) 
} 
 
// Crear el pool de conexiones con la configuración individual
const pool = mysql.createPool(dbConfig)

export const testConnection = async () => {
  try {
    const connection = await pool.getConnection()
    console.log("✅ Conexión a MySQL establecida correctamente")
    console.log(`📊 Host: ${dbConfig.host}:${dbConfig.port}`)
    console.log(`👤 Usuario: ${dbConfig.user}`)

    const [rows] = await connection.query("SELECT DATABASE() as db")
    console.log(`📁 Base de datos activa: ${rows[0].db}`)

    connection.release()
    return true
  } catch (error) {
    console.error("❌ Error conectando a MySQL:", error.message)
    console.error("💡 Verifica que:")
    console.error(`   1. MySQL esté corriendo en ${dbConfig.host}:${dbConfig.port}`)
    console.error(`   2. La base de datos '${dbConfig.database}' exista`)
    console.error(`   3. El usuario '${dbConfig.user}' tenga permisos correctos`)
    console.error(`   4. La contraseña sea correcta`)
    console.error("\n🔧 Para crear la base de datos ejecuta:")
    console.error(`   CREATE DATABASE ${dbConfig.database};`)
    return false
  }
}

// Función para ejecutar queries
export const executeQuery = async (query, params = []) => {
  try {
    const [results] = await pool.execute(query, params)
    return results
  } catch (error) {
    console.error("Error ejecutando query:", error)
    console.error("Query:", query)
    console.error("Params:", params)
    throw error
  }
}

// Función para transacciones
export const executeTransaction = async (queries) => {
  const connection = await pool.getConnection()
  try {
    await connection.beginTransaction()
    const results = []
    for (const { query, params } of queries) {
      const [result] = await connection.execute(query, params)
      results.push(result)
    }
    await connection.commit()
    return results
  } catch (error) {
    await connection.rollback()
    console.error("Error en transacción:", error)
    throw error
  } finally {
    connection.release()
  }
}

// Función para obtener estadísticas de la base de datos
export const getDatabaseStats = async () => {
  try {
    const [tables] = await pool.execute("SHOW TABLES")
    const stats = {}
    for (const table of tables) {
      const tableName = Object.values(table)[0]
      const [count] = await pool.execute(`SELECT COUNT(*) as count FROM ${tableName}`)
      stats[tableName] = count[0].count
    }
    return stats
  } catch (error) {
    console.error("Error obteniendo estadísticas:", error)
    return {}
  }
}

export default pool
