"use client"

import { useState, useEffect } from "react"
import { Dialog, Transition } from "@headlessui/react"
import { Fragment } from "react"
import { useCustomerStore } from "../../stores/customerStore"
import { useToast } from "../../hooks/useToast"
import Button from "../common/Button"
import {
  XMarkIcon,
  ExclamationTriangleIcon,
  UserIcon,
  EnvelopeIcon,
  PhoneIcon,
  CurrencyDollarIcon,
  DocumentTextIcon,
  PlusIcon,
  PencilIcon,
  IdentificationIcon, // Imported IdentificationIcon
} from "@heroicons/react/24/outline"

const CustomerForm = ({ customer, onClose, onSuccess }) => {
  const { createCustomer, updateCustomer, loading } = useCustomerStore()
  const { showToast } = useToast()

  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    document_number: "",
    credit_limit: "100000",
    notes: "",
    active: true,
  })

  const [errors, setErrors] = useState({})
  // Removed activeSection and completedSections states

  useEffect(() => {
    if (customer) {
      setFormData({
        name: customer.name || "",
        email: customer.email || "",
        phone: customer.phone || "",
        document_number: customer.document_number || "",
        credit_limit: customer.credit_limit?.toString() || "",
        notes: customer.notes || "",
        active: customer.active !== undefined ? customer.active : true,
      })
      // Removed section-related state updates
    } else {
      // Reset form for new customer
      setFormData({
        name: "",
        email: "",
        phone: "",
        document_number: "",
        credit_limit: "100000",
        notes: "",
        active: true,
      })
      // Removed section-related state updates
    }
    setErrors({})
    // Removed setActiveSection("basic")
  }, [customer])

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target
    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }))

    // Limpiar error del campo cuando el usuario empiece a escribir
    if (errors[name]) {
      setErrors((prev) => ({
        ...prev,
        [name]: "",
      }))
    }
  }

  // Removed validateSection function

  // Removed handleContinue, handleBack, handleSectionClick functions

  const validateForm = () => {
    const newErrors = {}

    if (!formData.name.trim()) {
      newErrors.name = "El nombre es requerido"
    } else if (formData.name.trim().length < 2) {
      newErrors.name = "El nombre debe tener al menos 2 caracteres"
    }

    if (!formData.document_number || !formData.document_number.trim()) {
      newErrors.document_number = "El número de documento es requerido"
    } else if (formData.document_number.trim().length < 7) {
      newErrors.document_number = "El número de documento debe tener al menos 7 caracteres"
    }

    // Email opcional pero debe ser válido
    if (formData.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = "El email no es válido"
    }

    // Teléfono opcional pero debe tener formato válido
    if (formData.phone && formData.phone.length < 8) {
      newErrors.phone = "El teléfono debe tener al menos 8 dígitos"
    }

    if (formData.credit_limit && Number.parseFloat(formData.credit_limit) < 0) {
      newErrors.credit_limit = "El límite de crédito no puede ser negativo"
    }

    // Solo para clientes nuevos, no permitir más de 100,000
    if (!customer && formData.credit_limit && Number.parseFloat(formData.credit_limit) > 100000) {
      newErrors.credit_limit =
        "El límite inicial no puede exceder $100,000. Podrás aumentarlo después de crear el cliente."
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    // Removed validation of all sections

    // Usar la validación completa del formulario
    if (!validateForm()) {
      showToast("Por favor corrige los errores en el formulario", "error")
      return
    }

    try {
      // Limpiar campos vacíos y preparar datos
      const cleanData = { ...formData }
      Object.keys(cleanData).forEach((key) => {
        if (typeof cleanData[key] === "string" && cleanData[key].trim() === "") {
          cleanData[key] = null
        }
      })

      // Convertir credit_limit a número
      if (cleanData.credit_limit) {
        cleanData.credit_limit = Number.parseFloat(cleanData.credit_limit)
      } else {
        cleanData.credit_limit = 100000
      }

      if (customer) {
        await updateCustomer(customer.id, cleanData)
        showToast("Cliente actualizado correctamente", "success")
      } else {
        await createCustomer(cleanData)
        showToast("Cliente creado correctamente", "success")
      }

      onSuccess()
    } catch (error) {
      console.error("Error guardando cliente:", error)
      showToast(error.message || "Error guardando cliente", "error")
    }
  }

  // Removed currentSectionIndex and isLastSection

  return (
    <Transition appear show={true} as={Fragment}>
      <Dialog as="div" className="relative z-50" onClose={onClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black bg-opacity-25 backdrop-blur-sm" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4">
            {" "}
            {/* Changed padding */}
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel className="w-full max-w-3xl transform overflow-hidden rounded-xl bg-white shadow-2xl transition-all">
                {" "}
                {/* Changed max-width and removed overflow-hidden */}
                <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200 bg-gradient-to-r from-blue-50 to-indigo-50">
                  {" "}
                  {/* Changed border and background */}
                  <div className="flex items-center gap-3">
                    {" "}
                    {/* Changed gap */}
                    <div className="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center">
                      {" "}
                      {/* Changed background */}
                      {customer ? (
                        <PencilIcon className="h-5 w-5 text-white" />
                      ) : (
                        <PlusIcon className="h-5 w-5 text-white" />
                      )}
                    </div>
                    <Dialog.Title as="h3" className="text-lg font-semibold text-gray-900">
                      {" "}
                      {/* Changed text color */}
                      {customer ? "Editar Cliente" : "Nuevo Cliente"}
                    </Dialog.Title>
                  </div>
                  <button
                    onClick={onClose}
                    className="text-gray-400 hover:text-gray-600 transition-colors" // Changed hover color
                  >
                    <XMarkIcon className="h-6 w-6" /> {/* Changed icon size */}
                  </button>
                </div>
                <form onSubmit={handleSubmit} className="p-6">
                  {" "}
                  {/* Added padding */}
                  <div className="space-y-5">
                    {" "}
                    {/* Changed spacing */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {" "}
                      {/* Changed gap */}
                      {/* Nombre */}
                      <div>
                        <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1.5">
                          {" "}
                          {/* Changed margin-bottom */}
                          Nombre <span className="text-red-500">*</span>
                        </label>
                        <div className="relative">
                          <UserIcon className="h-5 w-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />{" "}
                          {/* Changed icon size and position */}
                          <input
                            type="text"
                            name="name"
                            id="name"
                            value={formData.name}
                            onChange={handleChange}
                            className={`block w-full pl-10 pr-3 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                              errors.name ? "border-red-300 bg-red-50" : "border-gray-300"
                            }`} // Changed padding, border, text size, focus ring color
                            placeholder="Nombre completo"
                          />
                        </div>
                        {errors.name && (
                          <p className="mt-1 text-xs text-red-600 flex items-center gap-1">
                            {" "}
                            {/* Changed margin-top, text size, added gap */}
                            <ExclamationTriangleIcon className="h-3.5 w-3.5" /> {/* Changed icon size */}
                            {errors.name}
                          </p>
                        )}
                      </div>
                      {/* DNI/Documento */}
                      <div>
                        <label htmlFor="document_number" className="block text-sm font-medium text-gray-700 mb-1.5">
                          {" "}
                          {/* Changed margin-bottom */}
                          DNI/Documento <span className="text-red-500">*</span>
                        </label>
                        <div className="relative">
                          <IdentificationIcon className="h-5 w-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />{" "}
                          {/* Changed icon size and position */}
                          <input
                            type="text"
                            name="document_number"
                            id="document_number"
                            value={formData.document_number}
                            onChange={handleChange}
                            className={`block w-full pl-10 pr-3 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                              errors.document_number ? "border-red-300 bg-red-50" : "border-gray-300"
                            }`} // Changed padding, border, text size, focus ring color
                            placeholder="DNI, CUIT, etc."
                          />
                        </div>
                        {errors.document_number && (
                          <p className="mt-1 text-xs text-red-600 flex items-center gap-1">
                            {" "}
                            {/* Changed margin-top, text size, added gap */}
                            <ExclamationTriangleIcon className="h-3.5 w-3.5" /> {/* Changed icon size */}
                            {errors.document_number}
                          </p>
                        )}
                      </div>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {" "}
                      {/* Changed gap */}
                      {/* Email */}
                      <div>
                        <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1.5">
                          {" "}
                          {/* Changed margin-bottom */}
                          Email
                        </label>
                        <div className="relative">
                          <EnvelopeIcon className="h-5 w-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />{" "}
                          {/* Changed icon size and position */}
                          <input
                            type="email"
                            name="email"
                            id="email"
                            value={formData.email}
                            onChange={handleChange}
                            className={`block w-full pl-10 pr-3 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                              errors.email ? "border-red-300 bg-red-50" : "border-gray-300"
                            }`} // Changed padding, border, text size, focus ring color
                            placeholder="cliente@ejemplo.com"
                          />
                        </div>
                        {errors.email && (
                          <p className="mt-1 text-xs text-red-600 flex items-center gap-1">
                            {" "}
                            {/* Changed margin-top, text size, added gap */}
                            <ExclamationTriangleIcon className="h-3.5 w-3.5" /> {/* Changed icon size */}
                            {errors.email}
                          </p>
                        )}
                      </div>
                      {/* Teléfono */}
                      <div>
                        <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-1.5">
                          {" "}
                          {/* Changed margin-bottom */}
                          Teléfono
                        </label>
                        <div className="relative">
                          <PhoneIcon className="h-5 w-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />{" "}
                          {/* Changed icon size and position */}
                          <input
                            type="tel"
                            name="phone"
                            id="phone"
                            value={formData.phone}
                            onChange={handleChange}
                            className={`block w-full pl-10 pr-3 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                              errors.phone ? "border-red-300 bg-red-50" : "border-gray-300"
                            }`} // Changed padding, border, text size, focus ring color
                            placeholder="+54 11 1234-5678"
                          />
                        </div>
                        {errors.phone && (
                          <p className="mt-1 text-xs text-red-600 flex items-center gap-1">
                            {" "}
                            {/* Changed margin-top, text size, added gap */}
                            <ExclamationTriangleIcon className="h-3.5 w-3.5" /> {/* Changed icon size */}
                            {errors.phone}
                          </p>
                        )}
                      </div>
                    </div>
                    <div>
                      <label htmlFor="credit_limit" className="block text-sm font-medium text-gray-700 mb-1.5">
                        {" "}
                        {/* Changed margin-bottom */}
                        Límite de Crédito
                      </label>
                      <div className="relative">
                        <CurrencyDollarIcon className="h-5 w-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />{" "}
                        {/* Changed icon size and position */}
                        <input
                          type="number"
                          name="credit_limit"
                          id="credit_limit"
                          value={formData.credit_limit}
                          onChange={handleChange}
                          min="0"
                          max={!customer ? "100000" : undefined}
                          step="1000"
                          className={`block w-full pl-10 pr-3 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                            errors.credit_limit ? "border-red-300 bg-red-50" : "border-gray-300"
                          }`} // Changed padding, border, text size, focus ring color
                          placeholder="100000.00"
                        />
                      </div>
                      {errors.credit_limit && (
                        <p className="mt-1 text-xs text-red-600 flex items-center gap-1">
                          {" "}
                          {/* Changed margin-top, text size, added gap */}
                          <ExclamationTriangleIcon className="h-3.5 w-3.5" /> {/* Changed icon size */}
                          {errors.credit_limit}
                        </p>
                      )}
                      {!customer && (
                        <p className="mt-1 text-xs text-gray-500">
                          Límite inicial: $100,000 (máximo). Podrás aumentarlo después de crear el cliente.
                        </p>
                      )}
                    </div>
                    <div>
                      <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-1.5">
                        {" "}
                        {/* Changed margin-bottom */}
                        Notas
                      </label>
                      <div className="relative">
                        <DocumentTextIcon className="h-5 w-5 text-gray-400 absolute left-3 top-3" />{" "}
                        {/* Changed icon position */}
                        <textarea
                          name="notes"
                          id="notes"
                          rows={3} // Changed number of rows
                          value={formData.notes}
                          onChange={handleChange}
                          className="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none transition-all" // Changed padding, border, text size, focus ring color
                          placeholder="Información adicional..."
                        />
                      </div>
                    </div>
                    {customer && (
                      <div className="flex items-center gap-2 p-3 bg-gray-50 rounded-lg border border-gray-200">
                        {" "}
                        {/* Changed layout and styling */}
                        <input
                          id="active"
                          name="active"
                          type="checkbox"
                          checked={formData.active}
                          onChange={handleChange}
                          className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded" // Changed colors
                        />
                        <label htmlFor="active" className="text-sm font-medium text-gray-700">
                          Cliente activo
                        </label>
                      </div>
                    )}
                  </div>
                  <div className="flex items-center justify-end gap-3 mt-6 pt-4 border-t border-gray-200">
                    {" "}
                    {/* Changed gap, margin-top, padding, border */}
                    <Button
                      type="button"
                      variant="outline"
                      onClick={onClose}
                      disabled={loading}
                      className="px-4 py-2 text-sm bg-transparent" // Changed padding and text size
                    >
                      Cancelar
                    </Button>
                    <Button
                      type="submit"
                      onClick={handleSubmit}
                      disabled={loading}
                      className="px-4 py-2 text-sm bg-blue-600 hover:bg-blue-700" // Changed padding, text size, and colors
                    >
                      {loading ? "Guardando..." : customer ? "Actualizar" : "Crear Cliente"}
                    </Button>
                  </div>
                </form>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  )
}

export default CustomerForm
