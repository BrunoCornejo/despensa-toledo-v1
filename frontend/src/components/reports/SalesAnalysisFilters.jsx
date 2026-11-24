"use client"

import { useReportsStore } from "../../stores/reportsStore"
import { CalendarIcon } from "@heroicons/react/24/outline"

const SalesAnalysisFilters = () => {
  const { dateRange, selectedPeriod, setPeriod, setDateRange } = useReportsStore()

  const periods = [
    { value: "today", label: "Hoy" },
    { value: "yesterday", label: "Ayer" },
    { value: "last7days", label: "Últimos 7 días" },
    { value: "last30days", label: "Últimos 30 días" },
    { value: "thisMonth", label: "Este mes" },
    { value: "lastMonth", label: "Mes anterior" },
    { value: "thisYear", label: "Este año" },
    { value: "custom", label: "Personalizado" },
  ]

  const quickFilters = [
    { value: "last7days", label: "Semanal", icon: "📅" },
    { value: "thisMonth", label: "Mensual", icon: "📆" },
  ]

  const handleDateChange = (field, value) => {
    const newRange = { ...dateRange, [field]: value }
    setDateRange(newRange.start, newRange.end)
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex gap-2">
        {quickFilters.map((filter) => (
          <button
            key={filter.value}
            onClick={() => setPeriod(filter.value)}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
              selectedPeriod === filter.value
                ? "bg-blue-600 text-white shadow-md"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            <span>{filter.icon}</span>
            <span>{filter.label}</span>
          </button>
        ))}
      </div>

      {/* Selector de período y fechas personalizadas */}
      <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center">
        {/* Selector de período */}
        <div className="flex items-center space-x-2">
          <CalendarIcon className="h-5 w-5 text-gray-400" />
          <select
            value={selectedPeriod}
            onChange={(e) => setPeriod(e.target.value)}
            className="block w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
          >
            {periods.map((period) => (
              <option key={period.value} value={period.value}>
                {period.label}
              </option>
            ))}
          </select>
        </div>

        {/* Fechas personalizadas */}
        {selectedPeriod === "custom" && (
          <div className="flex items-center space-x-2">
            <input
              type="date"
              value={dateRange.start}
              onChange={(e) => handleDateChange("start", e.target.value)}
              className="block px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
            />
            <span className="text-gray-500">hasta</span>
            <input
              type="date"
              value={dateRange.end}
              onChange={(e) => handleDateChange("end", e.target.value)}
              className="block px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        )}
      </div>
    </div>
  )
}

export default SalesAnalysisFilters
